// § builtinMethodArgNamedByPath154
module top;
  string s = "abcd";
  int r;
  task automatic t(input string u);
    r = s.compare(u);
  endtask
  initial t("ab");
endmodule
