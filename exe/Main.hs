--{-# OPTIONS_GHC -Wno-incomplete-patterns #-}
module Main where
import Data.Char (ord)
import Data.List.Extra (splitOn)
import qualified Data.HashMap.Strict as HM
import System.Environment (getArgs)

newtype Program = Program (HM.HashMap Char Function)
data Function = Fun {arg :: Char, bias :: Arrow, body :: Exp}
data Arrow = LeftA | RightA
data Exp = Unit | Sum Exp Exp | Product Exp Exp | Appl Char Exp | Var Char deriving Show

data Value = U | R Value | L Value | P Value Value deriving (Show, Read)

-- PARSING

isKanji :: Char -> Bool
isKanji c = all ($ ord c) [(>=19968),(<=40959)]

isGreek :: Char -> Bool
isGreek c = all ($ ord c) [(>=945),(<=969)]

parseExp :: String -> Exp
parseExp e
    | null e = error "expected token"
    | head e == '⟨' && last e == '⟩' = parseExp (tail $ init e)
    | otherwise = case splitTermsOn '⊕' 0 [] e of
        [] -> error "syntax error"
        [e1] -> case splitTermsOn '×' 0 [] e1 of
            [] -> error "syntax error"
            [e2] -> case splitTermsOn '＄' 0 [] e2 of
                [] -> error "syntax error"
                [e3] -> case e3 of
                    "◯" -> Unit
                    [g] -> if isGreek g then Var g else error "expected lowercase greek letter"
                    _ -> error "syntax error"
                [a,b] -> case a of
                    [k] -> if isKanji k then Appl k (parseExp b) else error "expected kanji"
                    _ -> error "expected kanji"
                _ -> error "expected one argument in function application"
            ls -> foldr2 Product $ map parseExp ls
        ls -> foldr2 Sum $ map parseExp ls
    where
        splitTermsOn :: Char -> Int -> String -> String -> [String]
        splitTermsOn c prec run (r:remaining) = case r of
            '⟨' -> splitTermsOn c (prec+1) (r:run) remaining
            '⟩' -> splitTermsOn c (prec-1) (r:run) remaining
            _ -> if r /= c then splitTermsOn c prec (r:run) remaining else
                    if prec == 0 then reverse run : splitTermsOn c prec [] remaining else splitTermsOn c prec (r:run) remaining
        splitTermsOn _ prec run [] = if prec /= 0 then error "mismatched brackets" else [reverse run]

        foldr2 :: (t -> t -> t) -> [t] -> t
        foldr2 f [a,b] = f a b
        foldr2 f (x:xs) = f x (foldr2 f xs)
        foldr2 _ _ = error "what"

parseArrow :: Char -> Arrow
parseArrow c = case c of
    '⇀' -> LeftA
    '⇁' -> RightA
    _ -> error "expected arrow"

parseFunction :: String -> (Char,Function)
parseFunction (a:b:c:s)
    | not (isKanji a) = error "expected kanji"
    | not (isGreek b) = error "expected lowercase greek letter"
    | otherwise = (a,Fun {arg=b, bias=parseArrow c, body=parseExp s})
parseFunction _ = error "invalid function syntax"

parseProgram :: String -> Program
parseProgram = Program . HM.fromList . map parseFunction . splitOn ";"

-- EVALUATION

coerce :: HM.HashMap Char Function -> Exp -> Arrow -> Value -> Exp -> Value
coerce fns _ _ v (Appl f x) = let fn = HM.lookupDefault (error (f:" not defined")) f fns in coerce fns x (bias fn) v (body fn)
coerce fns var arrow v (Var _) = coerce fns var arrow v var

coerce _ _ _ _ Unit = U

coerce fns var arr (L x) (Sum a _) = L $ coerce fns var arr x a
coerce fns var arr (R x) (Sum _ b) = R $ coerce fns var arr x b

coerce fns var arr (P a b) (Product c d) = P (coerce fns var arr a c) (coerce fns var arr b d)

coerce fns var LeftA (P a _) x = coerce fns var LeftA a x
coerce fns var RightA (P _ b) x = coerce fns var LeftA b x

coerce fns var LeftA x (Sum a _) = L $ coerce fns var LeftA x a
coerce fns var RightA x (Sum _ b) = R $ coerce fns var LeftA x b

coerce fns var arr (L x) (Product a b) = coerce fns var arr x (Product a b)
coerce fns var arr (R x) (Product a b) = coerce fns var arr x (Product a b)

coerce fns var arr U (Product a b) = P (coerce fns var arr U a) (coerce fns var arr U b)

toExp :: Value -> Exp
toExp U = Unit
toExp (L a) = Sum (toExp a) Unit
toExp (R b) = Sum Unit (toExp b)
toExp (P a b) = Product (toExp a) (toExp b) 

main :: IO ()
main = do
    args <- getArgs
    case args of
        [a,b] -> do
            contents <- readFile a
            let Program fns = parseProgram contents
                m = HM.lookupDefault (error "主 not defined") '主' fns
            print $ coerce fns (toExp $ read b) (bias m) (read b) (body m)
        _ -> putStrLn "usage: ijo [filename] [input]"
    return ()