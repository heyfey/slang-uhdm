// b4_macro — AXIS 4: the MACRO shape, which the brief suspected of carrying
// the size/typespec difference.  All four rows pass a bare `1` to a `bit`
// formal from a CLASS METHOD; only the macro geometry changes:
//   M1 no macro at all
//   M2 one-line macro body
//   M3 two-line macro body, the call and its literal on the CONTINUATION line
//   M4 two-line macro body, the LITERAL on the second line of a call that
//      starts on the first
//   M5 the literal comes from a MACRO ARGUMENT
//   M6 the literal comes from a nested macro (`one60)
`define m2(ID) rep63(ID, 1)
`define m3(ID) \
   begin \
     rep63(ID, 1); \
   end
`define m4(ID) \
   rep63(ID, \
         1)
`define m5(ID, V) rep63(ID, V)
`define one60 1
`define m6(ID) rep63(ID, `one60)

package p64;
   function void rep63(string id, bit b);
   endfunction

   class c64;
      function void call_all();
         rep63("m1", 1);
         `m2("m2");
         `m3("m3")
         `m4("m4");
         `m5("m5", 1);
         `m6("m6");
      endfunction
   endclass
endpackage
