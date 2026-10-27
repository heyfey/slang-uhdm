// § classEventDynArrNamedEvent442
package p;
  class C;
    event d [];
    task t(); -> d[0]; endtask
  endclass
endpackage
module top;
  p::C h;
endmodule
