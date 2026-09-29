// § strLitContLineSpan220 — a continued string literal as a variable declaration initializer in a module, a function local, and a localparam
module top(output string o);
  string mv = "mod \
var";
  localparam string LP = "lp \
val";
  function automatic string f();
    string fl = "fn \
loc";
    return fl;
  endfunction
  initial o = {mv, LP, f()};
endmodule
