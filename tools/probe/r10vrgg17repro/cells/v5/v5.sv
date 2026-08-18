// vrgg17 v5 — BASE-KIND axis: module-instance array, scalar (non-array)
// instance, variable arrays (packed struct / unpacked logic), a 2-D interface
// array (the multi-dim ABSTAIN), and a DESCENDING module array.
interface sif; logic [31:0] value; endinterface
module leafm (output logic [31:0] value); assign value = 32'h0; endmodule
module sink (input logic [3:0] d); endmodule
typedef struct packed { logic [31:0] f; } st_t;
module top;
  sif   ifa[20]();
  sif   if2[4][4]();          // 2-D interface array
  leafm la[20]();             // MODULE-instance array
  leafm ld[20:10]();          // DESCENDING module array
  leafm one();                // SCALAR instance
  st_t  sarr[0:19];
  logic [31:0] varr [0:19];
  for (genvar i = 0; i < 2; i++) begin : g
    sink u_x1 (.d(la[2+3*i].value[0+:4]));      // module-instance array
    sink u_x2 (.d(ld[12+2*i].value[0+:4]));     // DESCENDING module array
    sink u_x3 (.d(one.value[0+:4]));            // SCALAR instance, no index
    sink u_x4 (.d(sarr[2+3*i].f[0+:4]));        // unpacked struct array (R-N5)
    sink u_x5 (.d(if2[i][1].value[0+:4]));      // 2-D interface array
    sink u_x6 (.d(ifa[2+3*i].value[0+:4]));     // control: interface array
  end
endmodule
