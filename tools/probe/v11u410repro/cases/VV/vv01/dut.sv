// § modVirtIfaceTd410
interface I; logic a; modport mp(input a); endinterface
module top;
  typedef virtual I.mp vm_t;
  vm_t h;
  I u();
  initial h = u;
endmodule
