using Gtk;

public class ConfirmExit : Dialog {
	public ConfirmExit() {
		title = "Confirmar operación";
		border_width = 10;
		create_widgets();
	}

	private void create_widgets() {
		var mensaje = new Label("Do you wish to save changes before closing?");

		add_button("Close without saving",ResponseType.ACCEPT);		
		add_button("Cancel",ResponseType.CANCEL);
		add_button("Save",ResponseType.APPLY);

		var content = get_content_area() as Box;
		content.pack_start(mensaje,true,true,0);
		content.spacing = 10;
		show_all();
	}
}