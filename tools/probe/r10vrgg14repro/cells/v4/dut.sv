// v4 — NON-port positions inside an unrolled gen-for: cont-assign RHS/LHS,
// procedural, localparam init, hier_path elements, part-selects and indexed
// part-selects, and a module-instance-ARRAY index.
interface sif;
  logic [31:0] v;
  modport mp (input v);
endinterface
module nleaf (input logic p);
  wire w; assign w = p;
endmodule
module top #(parameter int P = 5, parameter int W = 4)
  (input logic [63:0] arr, output logic [63:0] o);
  sif sarr [0:15] ();
  logic [63:0] mem [0:15];
  genvar i;
  for (i = 0; i < 2; ++i) begin : g
    wire        c0 = arr[i];
    wire        c1 = arr[3+i];
    wire        c2 = arr[2+4*i];
    wire        c3 = arr[i*2+1];
    wire  [7:0] c4 = arr[8*i +: 8];
    wire  [7:0] c5 = arr[8*i+7 -: 8];
    wire  [3:0] c6 = arr[4*i+3 : 4*i];
    wire        c7 = sarr[2+3*i].v[0];
    wire        c8 = sarr[i].v[1+2*i];
    wire  [1:0] c9 = sarr[4*i+1].v[2*i+1 -: 2];
    wire        ca = mem[2+3*i][4*i+1];
    localparam int LP = 4 + 2*i;
    wire        cb = arr[LP];
    wire        cc = arr[LP+i];
    nleaf u0 [1:0] (.p (arr[2+4*i]));
    always_comb begin
      o[2*i]   = arr[3+i];
      o[2*i+1] = arr[i*2+1];
    end
    initial begin
      automatic int t = arr[6+3*i];
    end
  end
endmodule
