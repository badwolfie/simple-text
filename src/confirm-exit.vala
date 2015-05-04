using Gtk;

public class ConfirmExit : Dialog {
	public ConfirmExit() {
		title = _("Confirm operation");
		border_width = 10;
		create_widgets();
	}

	private void create_widgets() {
		var mensaje = new Label(
			_("Do you wish to save changes before closing?"));

		add_button(_("Close without saving"),ResponseType.ACCEPT);		
		add_button(_("Cancel"),ResponseType.CANCEL);
		add_button(_("Save"),ResponseType.APPLY);

		var content = get_content_area() as Box;
		content.pack_start(mensaje,true,true,0);
		content.spacing = 10;
		show_all();
	}
}