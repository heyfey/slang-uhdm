// § builtinMethodArgNamedByPath154
module top;
  int q[$];
  int v = 5;
  initial begin
    q.push_back(v);
    q.insert(0, v);
  end
endmodule
