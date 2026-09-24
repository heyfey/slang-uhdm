// r10earl3 u.sv — does CALLING a package function from a module body make
// Surelog re-size the `'0` in that function's body (the aes_pkg:152 shape)?
// aes_transpose is called from aes_cipher_core / aes_mix_columns / aes_core
// with `assign x = aes_transpose(y);`.
package up;

  // 128-bit multi-dim, called below (the exact aes_transpose shape)
  function automatic logic [3:0][3:0][7:0] uf_called(logic [3:0][3:0][7:0] in);
    logic [3:0][3:0][7:0] transpose;
    transpose = '0;
    for (int j=0; j<4; j++) begin
      for (int i=0; i<4; i++) begin
        transpose[i][j] = in[j][i];
      end
    end
    return transpose;
  endfunction

  // same shape, NEVER called
  function automatic logic [3:0][3:0][7:0] uf_uncalled(logic [3:0][3:0][7:0] in);
    logic [3:0][3:0][7:0] transpose;
    transpose = '0;
    return transpose;
  endfunction

  // 8-bit, called
  function automatic logic [7:0] uf_small8(logic [7:0] in);
    logic [7:0] a;
    a = '0;
    return a ^ in;
  endfunction

endpackage

module um (input logic [3:0][3:0][7:0] d, input logic [7:0] d8,
           output logic [3:0][3:0][7:0] o, output logic [7:0] o8);
  assign o  = up::uf_called(d);
  assign o8 = up::uf_small8(d8);
endmodule
