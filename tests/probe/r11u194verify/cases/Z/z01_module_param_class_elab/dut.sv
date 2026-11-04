// (residue, no law of the two landings): a parameterized class declared inside a module and specialized there; --elabuhdm segfaults (rc 139) in every switch state, the definition view writes a database
module sub ();
  class box #(type E = int);
    E v;
  endclass
  box #(byte) b;
endmodule
module top;
  sub v ();
endmodule
