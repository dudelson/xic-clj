(ns xic.lexer.core
  (:require [clojure.java.io :as io])
  (:import [xic.java XiLexer]))

(let [rdr (io/reader "resources/add.xi")
      lexer (new XiLexer rdr)]
  (take-while some? (repeatedly #(. lexer nextToken))))
