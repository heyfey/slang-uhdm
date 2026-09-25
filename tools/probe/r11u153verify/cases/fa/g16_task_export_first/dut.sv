// law tfArgDpiExportFirstNoWrite153v
package p;
typedef enum logic [1:0] {A, B, C} e_t;
export "DPI-C" task t;
task automatic t(input e_t z);
endtask
endpackage
module top(output int o);
  assign o = 0;
endmodule
