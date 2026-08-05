// vi.sv — pass 11, ranked residue (6): "golden BARE / ours QUALIFIED".
// A package parameter passed as a FUNCTION-CALL ARGUMENT.  ExprEmit's
// func-call-arg arm names every such ref `pkg::P` unconditionally; Earlgrey's
// aes_sbox_canright reads `aes_mvm(data_i, A2X)` — the BARE, wildcard-imported
// spelling — and golden names that ref `A2X`.  Rows A/B are the two spellings
// of the same parameter; C/D repeat them for a SCALAR one, E/F inside a
// procedural call, so the arm's real key can be read off one file.
package vip;
  parameter logic [7:0] AVEC [4] = '{8'h1, 8'h2, 8'h3, 8'h4};
  parameter logic [7:0] ASCL = 8'h5;
endpackage

module via (
  input  logic [1:0] sel_i,
  output logic [7:0] a_o, b_o, c_o, d_o, e_o, f_o
);
  import vip::*;

  function automatic logic [7:0] pick(input logic [7:0] v [4],
                                      input logic [1:0] s);
    pick = v[s];
  endfunction
  function automatic logic [7:0] thru(input logic [7:0] v);
    thru = v;
  endfunction

  assign a_o = pick(AVEC, sel_i);        // A  bare, unpacked-array arg
  assign b_o = pick(vip::AVEC, sel_i);   // B  qualified, same parameter
  assign c_o = thru(ASCL);               // C  bare, scalar arg
  assign d_o = thru(vip::ASCL);          // D  qualified, same parameter

  logic [7:0] e_r, f_r;
  always_comb begin
    e_r = thru(ASCL);                    // E  bare, procedural call
    f_r = thru(vip::ASCL);               // F  qualified, procedural call
  end
  assign e_o = e_r;
  assign f_o = f_r;
endmodule

module vitop;
  logic [1:0] s;
  logic [7:0] a, b, c, d, e, f;
  via u (.sel_i(s), .a_o(a), .b_o(b), .c_o(c), .d_o(d), .e_o(e), .f_o(f));
endmodule
