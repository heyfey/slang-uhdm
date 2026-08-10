// pt20.sv — PASS 20 witness: when does an ELAB gen-scope PROCESS fold a
// MODULE PARAMETER read?  work@prim_prince's head after
// § genCaOpDeepBindGenLocal20 is prim_prince.sv:116:67 —
//   logic [NumRoundsHalf*2+1:0][DataWidth-1:0] data_state;
//   if (DataWidth == 64) begin : gen_middle_d64
//     always_comb begin : p_middle_d64
//       data_state_middle = prim_cipher_pkg::sbox4_64bit(
//           data_state[NumRoundsHalf], ...);
// where golden replaces the bit-select INDEX `NumRoundsHalf` with
// `constant {ct=9 sz=32 dec=5}` and we keep a ref_obj.  Round 1 of this file
// (an UNPACKED-array port indexed inside a LOCAL function call) measured NO
// fold on either side, so the candidates left are the indexed object (a
// module-level PACKED 2-D variable) and the callee (a PACKAGE function).
package pt20_pkg;
  function automatic logic [7:0] pf(input logic [7:0] x);
    return x;
  endfunction
endpackage

module pt20 #(
    parameter int W = 8,
    parameter int IDX = 3
) (
    input  logic [W-1:0] a,
    input  logic [W-1:0] arr [8],
    output logic [W-1:0] o1,
    output logic [W-1:0] o2,
    output logic [W-1:0] o3,
    output logic [W-1:0] o4,
    output logic [W-1:0] o5,
    output logic [W-1:0] o6
);

  logic [IDX*2+1:0][W-1:0] pk;   // module-level PACKED 2-D, like data_state
  always_comb pk[0] = a;

  function automatic logic [W-1:0] idf(input logic [W-1:0] x);
    return x;
  endfunction

  if (W == 8) begin : gi
    always_comb begin : p_if
      o1 = arr[IDX];                 // R1 unpacked port,   bare
      o2 = idf(arr[IDX]);            // R2 unpacked port,   local call
      o3 = pk[IDX];                  // R3 packed 2-D var,  bare
      o4 = idf(pk[IDX]);             // R4 packed 2-D var,  local call
      o5 = pt20_pkg::pf(pk[IDX]);    // R5 packed 2-D var,  PACKAGE call
      o6 = pt20_pkg::pf(arr[IDX]);   // R6 unpacked port,   PACKAGE call
    end
  end

endmodule
