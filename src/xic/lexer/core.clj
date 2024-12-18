(ns xic.lexer.core
  (:require [clojure.string :as str]
            [clojure.java.io :as io])
  (:import [xic.java XiLexer]))

(defn lex-file [filename]
  (let [rdr (io/reader filename)
        lexer (new XiLexer rdr)]
    (take-while some? (repeatedly #(. lexer nextToken)))))

(defn -token->str [token]
  (let [attr (.attribute token)]
    (format "%d:%d %s" (.line token) (.col token)
            (case (.name (.type token))
              "ID" (str "id " attr)
              "INT" (str "integer " attr)
              "CHAR" (str "character " attr)
              "STRING" (str "string " attr)
              "SYMBOL" attr
              "KEYWORD" attr
              "ERROR" (str "error:" attr)))))

(defn lex-and-write!
  "For input file name.xi, writes output file name.lexed containing the output from the lexer."
  [filename]
  (let [output-filename (str/replace filename #"\.xi$" ".lexed")
        lexer-output (map -token->str (lex-file filename))]
    (with-open [writer (io/writer output-filename)]
      (doseq [output-line lexer-output]
        (.write writer (str output-line "\n"))))))

(comment
  (str/join "." ["a" "b" "c"])
  (-> "/resources/dir.name/input.1.xi"
      (str/split #"\.")
      butlast
      vec
      (conj "lexed")
      (#(str/join "." %)))

  (str/replace "/resources/dir.name/input.1.xi" #"\.xi$" ".lexed")

  (map #(.-line %) (lex-file "e2e/pa1/add.xi"))
  (map -token->str (lex-file "e2e/pa1/ex1.xi"))

  (def token (first (lex-file "e2e/pa1/add.xi")))
  (use 'clojure.reflect)
  (reflect token)
  (.-type token)
  (.name (.type token))
  (. token type)
  (.toString token)
  (.getType token)

  ())
