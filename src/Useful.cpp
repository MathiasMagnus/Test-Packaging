#include <Useful.hpp>

#include "DefaultLocale.hpp"

#include <locale>

std::string capitalize(std::string in) {
  const auto &facet = std::use_facet<std::ctype<char>>(USEFUL_DEFAULT_LOCALE);
  for (auto &c : in) {
    c = facet.toupper(c);
  }
  return in;
}
