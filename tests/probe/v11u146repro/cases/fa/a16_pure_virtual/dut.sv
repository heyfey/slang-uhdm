// § tfArgTypedefLastWriter146
module top(output logic o);
  typedef enum logic {A, B} e_t;
  virtual class V;
    pure virtual function logic f(e_t x);
  endclass
  assign o = 1'b0;
endmodule
