package pkg3;

import java.lang.reflect.InvocationTargetException;

public class main {

	public static void main(String[] args) {
		// TODO Auto-generated method stub

		A a = new A();
		try {
			a.m();
		}catch (Exception e) {
			System.out.println("pas instanciť !");
			InjDependance i = new InjDependance();
			try {
				i.InjDep(a);
				a.m();
			} catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		
	}

}
