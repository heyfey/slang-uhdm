// § patLitFormFileAtRef256 (control: the package in the same file, the file already the setter's)
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  localparam logic [11:0] DataAddr = 12'h380;
  localparam bit XF = 1'b0;
  typedef struct packed { logic [3:0] zero1; logic [3:0] datasize; logic [11:0] dataaddr; } hartinfo_t;
endpackage
module top(output logic [19:0] o);
  localparam dm::hartinfo_t H = '{zero1: '0, datasize: dm::DataCount, dataaddr: dm::DataAddr};
  assign o = H;
endmodule
