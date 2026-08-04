// r10earl3 t.sv — `'0` FILL EXPANDED TO THE ASSIGNMENT-CONTEXT WIDTH inside a
// package function body (aes_pkg.sv:152 `transpose = '0;` at
// logic [3:0][3:0][7:0]).  golden: ct=3 sz=128 decompile = 128 '0' chars;
// ours: ct=3 sz=-1 decompile `'0`.
package tp;

  // the corpus shape: multi-dim packed var assigned '0 in a function body
  function automatic logic [3:0][3:0][7:0] tf_multi(logic [3:0][3:0][7:0] in);
    logic [3:0][3:0][7:0] transpose;
    transpose = '0;
    return transpose;
  endfunction

  // width controls
  function automatic logic [7:0] tf_small();
    logic [7:0] a;
    a = '0;
    return a;
  endfunction

  function automatic logic [7:0] tf_ones();
    logic [7:0] b;
    b = '1;
    return b;
  endfunction

  function automatic int tf_int();
    int c;
    c = '0;
    return c;
  endfunction

  // a DECLARATION initializer rather than an assignment statement
  function automatic logic [7:0] tf_declinit();
    logic [7:0] d = '0;
    return d;
  endfunction

  // package-level parameter (not a function body)
  parameter logic [7:0] PZ = '0;

endpackage

module tm (input logic clk, output logic [7:0] o);
  // the same shapes in a MODULE body, for the view distinguisher
  function automatic logic [7:0] mf();
    logic [7:0] e;
    e = '0;
    return e;
  endfunction
  logic [7:0] r;
  always_comb begin
    r = '0;
  end
  assign o = r ^ mf() ^ tp::tf_small();
endmodule
