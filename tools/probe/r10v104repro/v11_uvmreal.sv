// v104 arm V11 - the REAL uvm/ovm/svaunit version-string shapes, both `ifdef
// branches, in one file, so the law's own cells are re-measured standalone.
`define UVM_NAME UVM
`define UVM_MAJOR_REV 1
`define UVM_MINOR_REV 2
`define UVM_VERSION_STRING `"`UVM_NAME``-```UVM_MAJOR_REV``.```UVM_MINOR_REV```"
`define OVM_NAME OVM
`define OVM_MAJOR_REV 2
`define OVM_MINOR_REV 1
`define OVM_FIX_REV 2
`define OVM_VERSION_STRING `"`OVM_NAME``-```OVM_MAJOR_REV``.```OVM_MINOR_REV``.```OVM_FIX_REV`"
`define SVA_NAME SVAUNIT
`define SVA_MAJOR 3
`define SVA_MINOR 2
`define SVA_VERSION_STRING `"`SVA_NAME``-```SVA_MAJOR``.```SVA_MINOR```"
`define FIX d
`define UVM11_STRING `"`UVM_NAME``-```UVM_MAJOR_REV``.```UVM_MINOR_REV`FIX`"
package v11_pk;
  parameter string uvm_revision = `UVM_VERSION_STRING;
  parameter string ovm_revision = `OVM_VERSION_STRING;
  parameter string sva_revision = `SVA_VERSION_STRING;
  parameter string u11_revision = `UVM11_STRING;
endpackage
module v11_top; endmodule
