// NEGATIVE CONTROL: a package with classes and typedefs, NO import anywhere.
package ph206;
  class ii206;
    int c;
  endclass
  typedef ii206 ii206_t;
endpackage

module tf206;
  ph206::ii206_t h;
  initial h = null;
endmodule
