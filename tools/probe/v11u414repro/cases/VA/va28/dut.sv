// § clsTdArgAliasTwin414
interface ifc;
  typedef int i_t;
endinterface
module top;
  typedef int i_t;
  ifc i();
  task automatic t(i_t a);
  endtask
endmodule
