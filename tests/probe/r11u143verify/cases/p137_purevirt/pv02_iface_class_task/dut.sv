// § pureVirtProtoSpan137
// case pv02: a pure virtual task with ref arguments in an interface class
package ip;
  interface class Ifc;
    pure virtual task t(ref int a, input int b);
  endclass
endpackage
module top(); endmodule
