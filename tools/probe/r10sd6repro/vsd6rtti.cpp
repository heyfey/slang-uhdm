// Mechanical proof that any_cast<ref_obj*> is IS-A, so the `case uhdmbit_select:`
// and `case uhdmpart_select:` arms of importCopyRefs6 are UNREACHABLE.
#include <uhdm/uhdm.h>
#include <cstdio>
using namespace UHDM;
int main(){
  Serializer s;
  bit_select* bs = s.MakeBit_select();
  part_select* ps = s.MakePart_select();
  indexed_part_select* ips = s.MakeIndexed_part_select();
  var_select* vs = s.MakeVar_select();
  ref_obj* ro = s.MakeRef_obj();
  ref_var* rv = s.MakeRef_var();
  printf("any_cast<ref_obj*>(bit_select)          = %s\n", any_cast<ref_obj*>((any*)bs)?"NON-NULL  -> intercepted":"null");
  printf("any_cast<ref_obj*>(part_select)         = %s\n", any_cast<ref_obj*>((any*)ps)?"NON-NULL  -> intercepted":"null");
  printf("any_cast<ref_obj*>(indexed_part_select) = %s\n", any_cast<ref_obj*>((any*)ips)?"NON-NULL  -> intercepted":"null");
  printf("any_cast<ref_obj*>(var_select)          = %s\n", any_cast<ref_obj*>((any*)vs)?"NON-NULL  -> intercepted":"null");
  printf("any_cast<ref_obj*>(ref_obj)             = %s\n", any_cast<ref_obj*>((any*)ro)?"NON-NULL":"null");
  printf("any_cast<ref_obj*>(ref_var)             = %s\n", any_cast<ref_obj*>((any*)rv)?"NON-NULL (BAD)":"null (ok, unrelated hierarchies)");
  printf("any_cast<tf_call*>(bit_select)          = %s\n", any_cast<tf_call*>((any*)bs)?"NON-NULL":"null");
  return 0;
}
