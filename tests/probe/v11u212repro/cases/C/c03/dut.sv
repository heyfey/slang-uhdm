// § queueMemberSpanToDim212 — verifier: a queue member in a module-scope struct typedef, two queue members with comments between name and dimension
module dut(input logic i, output logic o);
  typedef struct {
    string names /* c */ [$];
    int    vals[ $ ];
  } t_t;
  t_t t;
  initial t.vals.push_back(1);
  assign o = i;
endmodule
