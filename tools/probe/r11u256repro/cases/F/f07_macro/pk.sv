// § patLitFormFileAtRef256 (the member value written through a macro in the module file)
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  localparam logic [11:0] DataAddr = 12'h380;
  localparam bit XF = 1'b0;
  typedef struct packed { logic [3:0] zero1; logic [3:0] datasize; logic [11:0] dataaddr; } hartinfo_t;
endpackage
