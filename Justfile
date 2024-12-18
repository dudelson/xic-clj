default: dev
dev: repl

clean:
    rm -rf build/

# generates java source code for lexer from specification file
jflex:
    rm -f java/XiLexer.java
    resources/jflex-1.6.1/bin/jflex -d "java" "resources/xi.flex"

# compiles local java source files so we can access them from clojure
# necessary for both full and local builds
compile: jflex
    clj -T:build compile

uberjar: clean compile
    clj -T:build uberjar
build: uberjar

repl: compile
    clojure -M:repl/reloaded

xic *args: compile
    clj -M:xic {{args}}

# does not have any prereq jobs because the test harness is designed to
# automatically call xic-build
e2e:
    resources/xth/xth -v 9 -ec -compilerpath . -testpath ./e2e ./e2e/xthScript
