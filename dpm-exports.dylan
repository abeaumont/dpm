module: dylan-user

define library dpm
  use common-dylan;
  use dfmc-environment-projects;
  use io;
  use system;
  use string-extensions;
  use build-system;
end library;

define module dpm
  use common-dylan;
  use dfmc-environment-projects;
  use format-out;
  use streams;
  use file-system;
  use locators;
  use locators-internals;
  use substring-search;
  use build-system;
end module;
