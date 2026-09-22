// v11u84 v2 — THE COMPILATION-UNIT IMPORT.
// CompilePackage::collectObjects_(FUNCTION) opens with
//   for (auto import : fC->getObjects(paPackage_import_item))
//       importPackage(m_package, ...)
// (Surelog src/DesignCompile/CompilePackage.cpp:143-152), and a FileContent's
// object map is filled by CompileFileContent for the FILE-level ($unit)
// constructs.  So a $unit import may put clones in EVERY package of that file,
// at the head of the batch and with no import member in slang's package.
// Does golden do that?  If it does, our listing is short by those entries.
package um1;
  wire  [7:0] u_net;
  logic [7:0] u_var = 8'd5;
endpackage

package um2;
  wire  [7:0] u_net2;
  logic [7:0] u_var2 = 8'd6;
endpackage

import um1::*;                  // $unit-level wildcard
import um2::u_net2;             // $unit-level explicit

package up1;                    // declares its own, imports nothing itself
  wire  [7:0] p_net;
  logic [7:0] p_var;
endpackage

package up2;                    // and one that does import
  import um1::*;
  wire  [7:0] q_net;
endpackage

module dut (output logic [31:0] o);
  import up1::*;
  assign o = {24'd0, p_net ^ p_var};
endmodule
