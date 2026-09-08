// r10v222 — ADVERSARIAL ARM K: the ROUTING FACES the brief names, all under
// one golden.  A call whose callee lives in an INTERFACE is the only thing
// this arm can reach; everything else here is a control that must be
// byte-identical on both binaries.
//   * a bare sibling callee whose arguments spell a CLASS-SCOPE call, a
//     `this.`-qualified call, a built-in METHOD call on a queue, a NESTED
//     call and a dotted NAME;
//   * the same argument forms around a PLAIN (non-interface) callee in a
//     module, in a package and in a class — the controls;
//   * a receiver-qualified callee reached from a module and from a class.
package pk22k;
   int g22k;
   function int pkfn22k(int a_x);
      return a_x;
   endfunction
endpackage

class obj22k;
   static function int sfn22k(int a_x);
      return a_x;
   endfunction
   string p22k;
   function string path22k();
      return p22k;
   endfunction
   function int self22k();
      return this.num22k();
   endfunction
   function int num22k();
      return 5;
   endfunction
endclass

interface if22k;
   int q22k[$];
   obj22k o22k;

   function void ctrl22k(string a_name, int a_kind, int a_t);
   endfunction
   function int fn22k(int a_x);
      return a_x;
   endfunction
   function void poke22k(string a_name, int a_kind);
   endfunction

   // k01 bare sibling callee, CLASS-SCOPE call argument.
   function void k01_classscope(int a_t);
      ctrl22k("", obj22k::sfn22k(1), a_t);
   endfunction

   // k02 bare sibling callee, PACKAGE-SCOPE call argument.
   function void k02_pkgscope(int a_t);
      ctrl22k("", pk22k::pkfn22k(2), a_t);
   endfunction

   // k03 bare sibling callee, BUILT-IN METHOD call argument.
   function void k03_builtin(int a_t);
      ctrl22k("", q22k.size(), a_t);
   endfunction

   // k04 bare sibling callee, NESTED user call whose own argument is dotted.
   function void k04_nested(int a_t);
      ctrl22k("", fn22k(o22k.num22k()), a_t);
   endfunction

   // k05 bare sibling callee, dotted NAME argument (no call).
   function void k05_dotname(int a_t);
      ctrl22k(o22k.p22k, 5, a_t);
   endfunction

   // k06 bare sibling callee, a `this.`-qualified call inside the argument.
   function void k06_thisarg(int a_t);
      ctrl22k("", o22k.self22k(), a_t);
   endfunction

   // k07 built-in METHOD call in statement position with a dotted argument.
   function void k07_builtinstmt();
      q22k.push_back(o22k.num22k());
   endfunction
endinterface

// CONTROLS: the same argument spellings around callees that do NOT live in an
// interface.  Nothing here may move.
package pk22k2;
   function void ctrl22k2(string a_name, int a_kind);
   endfunction
   function void c01_pkg();
      ctrl22k2("", pk22k::pkfn22k(1));
   endfunction
endpackage

class cls22k;
   obj22k o22k;
   function void ctrl22k3(string a_name, int a_kind);
   endfunction
   function void c02_cls();
      ctrl22k3(o22k.path22k(), obj22k::sfn22k(2));
   endfunction
endclass

module mod22k;
   if22k u_if22k();
   obj22k o22k;
   cls22k c22k;

   function void ctrl22k4(string a_name, int a_kind);
   endfunction

   // c04 MODULE plain call with a method-call argument (control).
   function void c04_mod();
      ctrl22k4(o22k.path22k(), obj22k::sfn22k(4));
   endfunction

   // k08 receiver-qualified INTERFACE callee reached from a module, with a
   //     class-scope call argument — must STAY a method call.
   function void k08_qual();
      u_if22k.poke22k(o22k.path22k(), obj22k::sfn22k(8));
   endfunction
endmodule
