// v104 arm V14 - an arg-LESS stringification invoked from inside a macro WITH
// arguments (the fence must key on the `define that OWNS the `" , not on the
// invocation), and a multi-line `define with args whose `" sits on a
// continuation line (the enclosure walk must still find the formal list).
`define IN1 `"a``-``b`"
`define OUT1(x) {`IN1, x}
`define ML(a,b) \
    { "lead", \
      `"a``-``b`", \
      "tail" }
`define MLNOARG \
    { "lead", \
      `"c``-``d`", \
      "tail" }
package v14_pk;
  parameter string c1 = `IN1;
endpackage
module v14_top;
  string arr[3];
  string s;
  initial begin
    s = `IN1;
    arr = `ML(a,b);
    arr = `MLNOARG;
    $display(`OUT1("z"));
  end
endmodule
