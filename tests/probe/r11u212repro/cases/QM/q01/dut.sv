// § queueMemberSpanToDim212 — an unpacked package struct typedef with a queue member (uvm_cmdline_parsed_arg_t's `string args[$];`)
package p;
  typedef struct {
    string arg;
    string args[$];
    int unsigned used;
  } a_t;
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
