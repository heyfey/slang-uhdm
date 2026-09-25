// § unsupportedTsInitEnd152
interface ifc;
  logic [31:0] a;
  covergroup cg;
    coverpoint a;
  endgroup
  cg cg_inst = new;
endinterface
module top;
  ifc i();
endmodule
