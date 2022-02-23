
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maps/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:maps/constants/app_colors.dart';
import 'package:maps/constants/strings.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: must_be_immutable
class AppDrawer extends StatelessWidget {
   AppDrawer({Key? key}) : super(key: key);
  
  PhoneAuthCubit phoneAuthCubit = PhoneAuthCubit();

  Widget buildDrawerHeader(context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(70, 10, 70, 10),
          decoration: BoxDecoration(shape: BoxShape.rectangle ,color: Colors.blue[100]),
          child: Image.asset('assets/images/athar.jpg',fit: BoxFit.cover,),
        ),
        const Text('Athar Hasan',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
        const SizedBox(height: 5,),
        BlocProvider<PhoneAuthCubit>(
            create: (context) => phoneAuthCubit,
        child: Text('${phoneAuthCubit.getLoggedInUser().phoneNumber}',
          style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),),

      ],
    );
  }

  Widget buildDrawerListItem ({required IconData leadingIcon, required String title, Widget? trailing,
  Function()? onTap, Color? color}) {
    return ListTile(
      leading: Icon(leadingIcon, color: color?? AppColors.blue,),
      title: Text(title),
      trailing: trailing??= const Icon(Icons.arrow_right, color: AppColors.blue,),
      onTap: onTap,
    );
  }

  Widget buildDrawerListItemDivider() {
    return const Divider(
      height: 0,
      thickness: 1,
      indent: 18,
      endIndent: 24,
    );
  }

  void _launchURL(String url) async {
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  Widget buildSocialMediaIcon(IconData icon, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Icon(
          icon, color: AppColors.blue,
        size: 35,
      ),
    );
  }

  Widget buildSocialMediaRow() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(start: 16),
      child: Row(
        children: [
          buildSocialMediaIcon(FontAwesomeIcons.linkedin, 'https://www.linkedin.com/in/athar-hasan-274838203/'),
          const SizedBox(width: 15,),
          buildSocialMediaIcon(FontAwesomeIcons.github, 'https://github.com/atharhasan?tab=repositories'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ignore: sized_box_for_whitespace
          Container(height: 280,
          child: DrawerHeader(decoration: BoxDecoration(color: Colors.blue[100]),
              child: buildDrawerHeader(context)),),
          buildDrawerListItem(leadingIcon: Icons.person, title: 'My Profile'),
          buildDrawerListItemDivider(),
          buildDrawerListItem(leadingIcon: Icons.history, title: 'Places History',onTap: () {}),
          buildDrawerListItemDivider(),
          buildDrawerListItem(leadingIcon: Icons.settings, title: 'Settings'),
          buildDrawerListItemDivider(),
          buildDrawerListItem(leadingIcon: Icons.help, title: 'Help'),
          buildDrawerListItemDivider(),
          BlocProvider<PhoneAuthCubit>(
              create: (context) => phoneAuthCubit,
          child: buildDrawerListItem(leadingIcon: Icons.logout, title: 'Log Out',
          onTap: () async {
            await phoneAuthCubit.logOut();
            Navigator.of(context).pushReplacementNamed(loginScreen);
          },
          color: Colors.red , trailing: const SizedBox()),
          ),
          const SizedBox(height: 180,),
          ListTile(leading: Text('Follow us',style: TextStyle(color: Colors.grey[600]),),),
          buildSocialMediaRow(),
          
        ],
      ),
    );
  }
}
