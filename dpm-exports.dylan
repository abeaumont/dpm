module: dylan-user

define library dpm
  use common-dylan;
  use io;
  use system;
  use build-system;
end library;

define module dpm
  use common-dylan;
  use format-out;
  use streams;
  use file-system;
  use locators;
  use locators-internals;
  use build-system;
end module;
