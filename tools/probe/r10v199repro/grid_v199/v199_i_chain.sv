package vpi_inner;
  parameter I_UHEX = 'hf000000;
  parameter I_UDEC = 12;
endpackage
package vpi_outer;
  import vpi_inner::*;
  export vpi_inner::*;
  parameter O_UHEX = 'hbeef;
endpackage
import vpi_outer::*;
module vi(input logic clk);
  logic q;
  always_ff @(posedge clk) q <= 1'b0;
endmodule
