// residue (no law landed): a net-declaration assignment whose right side is a system call (sv-tests p599), see README
module top (input logic [7:0] a);
  function automatic logic [7:0] f(logic [7:0] x); return x; endfunction
  wire [7:0] w1 = f(a);
  wire [7:0] w2 = a;
  logic [7:0] v = $signed(a);
endmodule
