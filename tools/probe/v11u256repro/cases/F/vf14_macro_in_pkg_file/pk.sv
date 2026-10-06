// § patLitFormFileAtRef256 (the member value written by a macro defined in the package file)
`define DC dm::DataCount
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  localparam logic [11:0] DataAddr = 12'h380;
  typedef struct packed { logic [3:0] zero1; logic [3:0] datasize; logic [11:0] dataaddr; } hartinfo_t;
endpackage
