// § pcwRefLastWriter250
package c_pkg;
  localparam aw = 6;
  localparam ba = (aw)'('h3);
endpackage
package u_pkg;
  import c_pkg::*;
  localparam z = 1;
endpackage
interface ifc;
  import c_pkg::*;
  logic [31:0] v;
endinterface
module top import u_pkg::*; import c_pkg::*; (output logic [31:0] o);
  ifc i0();
  if (1) begin : g
    assign o = ba + z;
  end
endmodule
