unit Glue.Binding.Impl.Binding;

interface

uses
   System.Classes,
   Vcl.StdCtrls,
   System.SysUtils,
   Rtti,
   Glue.Binding,
   Generics.Collections,
   Glue.NotifyPropertyChanging,
   Glue.Binding.BindingContext,
   Glue.BindableBase,
   Glue.Converter,
   Glue.Enum,
   Glue.Converter.Impl.GenericConverter;

type

   TBinding = class(TInterfacedObject, IBinding)
   protected
      FComponent: TComponent;
      FViewModel: INotifyPropertyChanging;
      FMode: TModeBinding;
      FBindContext: TBindContext;
      FRTTIContext: TRttiContext;
      FPropertyVM: TRttiProperty;
      FPropertyUI: TRttiProperty;
      FComponentType: TRttiType;
      FViewModelType: TRttiType;
      FConverter : IConverter;
   protected
      procedure OnChange(Sender: TObject);
      procedure ProcessBinding();
   public
      constructor Create(Mode: TModeBinding; Component: TComponent; ViewModel: INotifyPropertyChanging; Converter : IConverter; Context: TBindContext);
      procedure UpdateView();
   end;

implementation

{ TBinding }

constructor TBinding.Create(Mode: TModeBinding; Component: TComponent; ViewModel: INotifyPropertyChanging; Converter : IConverter; Context: TBindContext);
begin

   FMode := Mode;

   FComponent := Component;

   FViewModel := ViewModel;

   FBindContext := Context;

   FRTTIContext := TRttiContext.Create;

   ProcessBinding;

   FConverter := Converter;

   if FConverter is TGenericConverter then
      TGenericConverter(FConverter).SetPropertiesType(FPropertyUI.PropertyType, FPropertyVM.PropertyType);

end;

procedure TBinding.OnChange(Sender: TObject);
var
   Value: TValue;
begin

   Value := FConverter.coerceToVM(FPropertyUI.GetValue(TEdit(FComponent)), FComponent);

   FPropertyVM.SetValue(FViewModel as TObject, Value);

end;

procedure TBinding.ProcessBinding;
var
   objType: TRttiType;
   Prop: TRttiProperty;
begin

   objType := FRTTIContext.GetType(TObject(FViewModel).ClassType);

   FPropertyVM := objType.GetProperty(FBindContext.AttributeVM);

   objType := FRTTIContext.GetType(FComponent.ClassType);

   FPropertyUI := objType.GetProperty(FBindContext.AttributeUI);

   if FMode = mbLoad then
      Exit;

   Prop := objType.GetProperty('OnChange');

   if Prop = nil then
      Prop := objType.GetProperty('OnClick');

   if Prop = nil then
      raise Exception.Create('Property OnChange not found');

   Prop.SetValue(FComponent, TValue.From<TNotifyEvent>(OnChange));

end;

procedure TBinding.UpdateView;
var
   Value: TValue;
begin

   if FMode = mbSave then
      Exit;

   Value := FConverter.coerceToUI(FPropertyVM.GetValue(FViewModel as TObject), FComponent);

   FPropertyUI.SetValue(FComponent, Value);

end;

end.
