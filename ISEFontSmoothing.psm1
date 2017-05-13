
$Local:ISEFontSmoothingCSharpCode = @'
namespace ISEFontSmoothing
{
  using System;
  using System.Collections.Generic;
  using System.ComponentModel.Composition;
  using System.Reflection;
  using System.Windows;
  using System.Windows.Media;
  // There is no dependency on Visual Studio, - these namespaces are part of Microsoft.PowerShell.Editor assembly:
  using Microsoft.VisualStudio.Text;
  using Microsoft.VisualStudio.Text.Editor;
  using Microsoft.VisualStudio.Utilities;

  public static class ISEFontSmoother
  {
    public static void InjectTextEditorFactoryService()
    {
      Type editorImportsType = Type.GetType("Microsoft.Windows.PowerShell.Gui.Internal.EditorImports, Microsoft.PowerShell.GPowerShell, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL", true);
      FieldInfo valueField = editorImportsType.GetField("value", BindingFlags.Static | BindingFlags.NonPublic);
      FieldInfo textEditorFactoryServiceField = editorImportsType.GetField("textEditorFactoryService", BindingFlags.NonPublic | BindingFlags.Instance);
      object editorImportsObject = valueField.GetValue(null);
      object existingFactory = textEditorFactoryServiceField.GetValue(editorImportsObject);
      FontSmoothingTextEditorFactoryService fontSmoother = new FontSmoothingTextEditorFactoryService(existingFactory as ITextEditorFactoryService);
      textEditorFactoryServiceField.SetValue(editorImportsObject, fontSmoother);
    }
  }

  internal static class FontSmoother
  {
    public static void Smooth(DependencyObject element)
    {
      if (element != null)
      {
        TextOptions.SetTextFormattingMode(element, TextFormattingMode.Ideal);
        TextOptions.SetTextRenderingMode(element, TextRenderingMode.Auto);
        TextOptions.SetTextHintingMode(element, TextHintingMode.Fixed);
      }
    }
  }

  internal sealed class ISEFontSmoothingTextViewMonitor
  {
    private IWpfTextView textView;

    public ISEFontSmoothingTextViewMonitor(IWpfTextView textView_)
    {
      this.textView = textView_;
      this.textView.LayoutChanged += new EventHandler<TextViewLayoutChangedEventArgs>(this.OnTextViewLayoutChanged);
      this.textView.Closed += new EventHandler(this.OnTextViewClosed);
    }

    private void Update()
    {
      FontSmoother.Smooth(this.textView.VisualElement);
    }

    private void OnTextViewLayoutChanged(object sender, TextViewLayoutChangedEventArgs e)
    {
      this.Update();
    }

    private void OnTextViewClosed(object sender, EventArgs e)
    {
      this.textView.LayoutChanged -= new EventHandler<TextViewLayoutChangedEventArgs>(this.OnTextViewLayoutChanged);
      this.textView.Closed -= new EventHandler(this.OnTextViewClosed);
      this.textView = null;
    }
  }

  [TextViewRole("DOCUMENT")]
  [ContentType("powershell"), Export(typeof(IWpfTextViewCreationListener))]
  internal sealed class ISEFontSmoothingTextViewsManager : IWpfTextViewCreationListener
  {
    public void TextViewCreated(IWpfTextView textView)
    {
      new ISEFontSmoothingTextViewMonitor(textView);
    }
  }

  internal sealed class FontSmoothingTextEditorFactoryService : ITextEditorFactoryService
  {
    private readonly ITextEditorFactoryService original;
    private readonly ISEFontSmoothingTextViewsManager smoother;

    public FontSmoothingTextEditorFactoryService(ITextEditorFactoryService existing)
    {
      if (existing == null)
      {
        throw new ArgumentNullException("existing");
      }

      this.original = existing;
      this.smoother = new ISEFontSmoothingTextViewsManager();
    }

    public ITextViewRoleSet AllPredefinedRoles
    {
      get { return this.original.AllPredefinedRoles; }
    }

    public IWpfTextView CreateTextView()
    {
      IWpfTextView view = this.original.CreateTextView();
      this.smoother.TextViewCreated(view);
      return view;
    }

    public IWpfTextView CreateTextView(ITextBuffer textBuffer)
    {
      IWpfTextView view = this.original.CreateTextView(textBuffer);
      this.smoother.TextViewCreated(view);
      return view;
    }

    public IWpfTextView CreateTextView(ITextBuffer textBuffer, ITextViewRoleSet roles)
    {
      IWpfTextView view = this.original.CreateTextView(textBuffer, roles);
      this.smoother.TextViewCreated(view);
      return view;
    }

    public IWpfTextView CreateTextView(ITextBuffer textBuffer, ITextViewRoleSet roles, IEditorOptions parentOptions)
    {
      IWpfTextView view = this.original.CreateTextView(textBuffer, roles, parentOptions);
      this.smoother.TextViewCreated(view);
      return view;
    }

    public IWpfTextView CreateTextView(ITextDataModel dataModel, ITextViewRoleSet roles, IEditorOptions parentOptions)
    {
      IWpfTextView view = this.original.CreateTextView(dataModel, roles, parentOptions);
      this.smoother.TextViewCreated(view);
      return view;
    }

    public IWpfTextView CreateTextView(ITextViewModel viewModel, ITextViewRoleSet roles, IEditorOptions parentOptions)
    {
      IWpfTextView view = this.original.CreateTextView(viewModel, roles, parentOptions);
      this.smoother.TextViewCreated(view);
      return view;
    }

    public IWpfTextViewHost CreateTextViewHost(IWpfTextView wpfTextView, bool setFocus)
    {
      return this.original.CreateTextViewHost(wpfTextView, setFocus);
    }

    public ITextViewRoleSet CreateTextViewRoleSet(params string[] roles)
    {
      return this.original.CreateTextViewRoleSet(roles);
    }

    public ITextViewRoleSet CreateTextViewRoleSet(IEnumerable<string> roles)
    {
      return this.original.CreateTextViewRoleSet(roles);
    }

    public ITextViewRoleSet DefaultRoles
    {
      get { return this.original.DefaultRoles; }
    }

    public ITextViewRoleSet NoRoles
    {
      get { return this.original.NoRoles; }
    }

    public event EventHandler<TextViewCreatedEventArgs> TextViewCreated
    {
      add { this.original.TextViewCreated += value; }
      remove { this.original.TextViewCreated -= value; }
    }
  }
}
'@

$Local:ISEFontSmoothingReferences = @(
    'mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089',
    'System, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089',
    'Microsoft.PowerShell.Editor, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35',
    'PresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35',
    'PresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35',
    'System.ComponentModel.Composition, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089',
    'WindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35',
    'System.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')

if (-not ([System.Management.Automation.PSTypeName]'ISEFontSmoothing.ISEFontSmoother').Type)
{
    Add-Type -TypeDefinition $Local:ISEFontSmoothingCSharpCode -ReferencedAssemblies $Local:ISEFontSmoothingReferences
}


[ISEFontSmoothing.ISEFontSmoother]::InjectTextEditorFactoryService()

