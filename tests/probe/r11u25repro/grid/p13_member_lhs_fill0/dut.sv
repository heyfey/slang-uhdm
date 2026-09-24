module top #(parameter int K = 9, parameter int PBal = 1)
  (input logic [31:0] a, input logic [31:0] b, input logic [4:0] s,
   output logic [31:0] o2, output logic [31:0] o3);
  if (1) begin : gb
    typedef struct packed { logic [15:0] m; logic [15:0] n; } st_t;
    st_t lv;
    assign lv.m = '0;
    assign o2 = lv;
  end
endmodule
