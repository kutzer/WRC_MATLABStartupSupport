edtSvc  = com.mathworks.mlservices.MLEditorServices ;  %// get the main editor service ;
edtSvc.getEditorApplication.close ;             %// Close all editor windows. Prompt to save if necessary.
edtSvc.getEditorApplication.closeNoPrompt ;     %// Close all editor windows, WITHOUT SAVE!!