// r10uvm187 probe0 — the head's exact shape, reduced.
package uvm_like_pkg;
  typedef int UVM_FILE;
  parameter UVM_FILE UVM_STDIN  = 32'h8000_0000;
  parameter UVM_FILE UVM_STDOUT = 32'h8000_0001;
  typedef bit [7:0] b8_t;
  parameter b8_t PB = 8'hAA;
  typedef int i_t;
  parameter i_t PI = 5;
  localparam i_t LI = 6;
endpackage
