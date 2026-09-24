// LAW 1 over an unpacked array of a PACKED STRUCT net.
module top(input logic [31:0] a, output logic [31:0] o);
  typedef struct packed { logic [15:0] hi; logic [15:0] lo; } st_t;
  st_t sarr[2];
  if (1) begin : gb
    assign sarr = '{a, a};
  end
  assign o = sarr[0];
endmodule
