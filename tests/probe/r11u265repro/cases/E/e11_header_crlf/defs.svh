// § cloneMembEnumAtHomeListing265 (the typedef and the formal writer in an included header, CRLF)
typedef enum {OK, NOK} st_e;
typedef struct { int a; st_e status; } op_t;
task g(output st_e s2);
  s2 = OK;
endtask
