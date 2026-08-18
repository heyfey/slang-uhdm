interface sif;
  logic [31:0] v;
  modport mp (input v);
endinterface

module leaf (input logic p);
  wire w;
  assign w = p;
endmodule

module top #(
  parameter int P = 5,
  parameter int W = 4
) (
  input  logic [63:0] arr,
  output logic [63:0] o
);
  sif sarr [0:15] ();
  genvar i;
  for (i = 0; i < 2; ++i) begin : g
    // cont_assign RHS with a genvar bit-select and a genvar part-select
    wire       ca0 = arr[i];
    wire       ca1 = arr[3+i];
    wire [7:0] ca2 = arr[i*8 +: 8];
    wire [3:0] ca3 = arr[i +: W];
    wire       ca4 = arr[P+i];
    // hier_path with a genvar element index and a genvar part-select
    wire       hp0 = sarr[i].v[0];
    wire       hp1 = sarr[2+3*i].v[1+2*i +: 1];
    // localparam depending on the genvar
    localparam int LP = 4 + 2*i;
    wire       ca5 = arr[LP];
    // port actual with an operation
    leaf ua (.p (arr[6+3*i]));
    // if-generate condition on the genvar
    if (i == 1) begin : gi
      wire gz = arr[i];
    end
    // for-loop bound inside an always using the genvar
    always_comb begin
      o[i] = 1'b0;
      for (int k = 0; k < i + 2; ++k)
        o[i] = o[i] ^ arr[k + 2*i];
    end
  end
endmodule
