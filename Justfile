repl:
    clojure -M:repl/reloaded

clean:
    rm -r build/

jflex:
    rm -f java/XiLexer.java
    resources/jflex-1.6.1/bin/jflex -d "java" "resources/xi.flex"

compile: jflex
    clj -T:build compile

# includes compilation step inside of build.clj
jar: jflex
    clj -T:build jar

# alias for `jar`
build: jar

xic *args: build
    clj -M:xic {{args}}
