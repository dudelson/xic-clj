repl:
    clojure -M:repl/reloaded

jflex:
    rm -f src/xic/lexer/XiLexer.java
    resources/jflex-1.6.1/bin/jflex -d "src/xic/lexer" "resources/xi.flex"

xic *args: jflex
    clj -M:xic {{args}}
