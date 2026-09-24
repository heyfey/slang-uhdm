// § genvarIdxFoldRerender14 ARM pc5 — the NON-PORT positions.  Golden keeps the
// genvar reference in a cont_assign / procedural index (measured: Rggen's
// `register_if[i].write_data` and `bit_field_if.value[8 + 16 * k+:8]`), so this
// cell must be BYTE-IDENTICAL between the two binaries.
module top (input logic [63:0] arr, output logic [63:0] o);
  genvar i;
  for (i = 0; i < 2; ++i) begin : g
    wire       ca0 = arr[2 + 4*i];
    wire [7:0] ca1 = arr[8*i +: 8];
    always_comb o[i] = arr[3 + 2*i];
  end
endmodule
