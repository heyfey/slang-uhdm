// r10uvm27 t37g — vpiConstantVariable on CLASS PROPERTIES.  We stamp it on
// package, module and interface variables but never on a class member, and
// golden's `const static string type_name` (uvm_object_defines.svh:428, the
// `uvm_object_utils` macro expansion) reads vpiConstantVariable=1 against our
// 0 — one shared object that shows up in 161 of the localizer's failing
// package-listing elements.  Both qualifier orders, both with and without
// `static`, and the non-const controls.
package pk;

  class c;
    const static string a = "x";
    static const string b = "y";
    const string cc = "z";
    static string d = "w";
    string e;
    const int f = 3;
    static const int g = 4;
    local const string h = "h";
    protected const string i = "i";
    const string j;
    rand int k;
    string a2;
    function void go();
      a2 = "l";
    endfunction
  endclass

endpackage

module top;
  pk::c h;
  initial h = new();
endmodule
